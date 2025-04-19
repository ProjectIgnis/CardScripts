--Ｓｐ－ミラクル·フュージョ
--Speed Spell - Miracle Fusion
--rescripted by Naim to match the Fusion Summon procedure
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_ELEMENTAL_HERO),aux.FALSE,s.fextra,Fusion.BanishMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chk==0 then return tc and tc:IsCanRemoveCounter(tp,0x91,3,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	tc:RemoveCounter(tp,0x91,3,REASON_COST)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE|LOCATION_GRAVE)
end