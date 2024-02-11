--ギルフォード・ザ・レジェンド
--Gilford the Legend
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- Equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e)return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)end)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.eqfilter(c,g)
	return c:IsEquipSpell() and g:IsExists(s.eqcheck,1,nil,c)
end
function s.eqcheck(c,ec)
	return Card.CheckEquipTargetRush(ec,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,0,nil)
	local eq=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_GRAVE,0,nil,g)
	if ft>#eq then ft=#eq end
	if ft>3 then ft=3 end
	if ft==0 then return end
	for i=1,ft do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local ec=eq:Select(tp,1,1,nil):GetFirst()
		eq:RemoveCard(ec)
		local tc=g:FilterSelect(tp,s.eqcheck,1,1,nil,ec):GetFirst()
		Duel.Equip(tp,ec,tc,true,true)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and #eq>0 and not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.EquipComplete()
			return
		end
	end
	Duel.EquipComplete()
end