--平行世界融合 (Manga)
--Parallel World Fusion (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,nil,aux.FALSE,s.fextra,Fusion.ShuffleMaterial)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup,Card.IsAbleToDeck),tp,LOCATION_REMOVED,0,nil)
end