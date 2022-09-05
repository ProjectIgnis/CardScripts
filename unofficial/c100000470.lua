--スピリッツ・フュージョン
--Soul Fusion
--scripted by Naim (to match the Fusion Summon procedure)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,nil,aux.FALSE,s.fextra,Fusion.BanishMaterial,nil,nil,nil,nil,nil,nil,nil,nil,nil,s.extratg)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end