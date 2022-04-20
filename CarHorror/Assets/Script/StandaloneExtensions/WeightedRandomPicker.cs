using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

namespace PMExtensions
{
    [System.Serializable]
    public class WeightedRandomList<T>
    {
        [ListDrawerSettings(Expanded = true)][LabelText(" ")]
        public List<WeightedRandom> weightedList = new List<WeightedRandom>();
        private int totalWeight = -1;

        public T Pick()
        {
            if (totalWeight < 0) RefreshTotalWeight();

            int rand = Random.Range(0, totalWeight);
            foreach(WeightedRandom wr in weightedList)
            {
                if(rand < wr.Probability)
                {
                    return wr.Item;
                }
                else
                {
                    rand -= wr.Probability;
                }
            }

            // This should never happen
            Debug.LogError("PickWeightedRandom : random outside of totalWeight ?!");
            return default(T);
        }

        public void RefreshTotalWeight()
        {
            totalWeight = 0;
            foreach (WeightedRandom wr in weightedList)
            {
                totalWeight += wr.Probability;
            }
        }

        [System.Serializable]
        public struct WeightedRandom
        {
            [HideLabel] [HorizontalGroup("")] public T Item;
            [HideLabel] [HorizontalGroup("")] public int Probability;
        }
    }

}