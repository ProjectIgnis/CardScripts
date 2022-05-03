--オーバーロード・フュージョン
--Overload Fusion
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.ffilter,Fusion.OnFieldMat(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	c:RegisterEffect(e1)
end
function s.ffilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
end