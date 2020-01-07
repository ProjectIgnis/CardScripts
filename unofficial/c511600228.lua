--ドローン・アステロイド
--Drone Asteroid
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15341821,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009746,0x581,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ft=math.min(Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE),Duel.GetLocationCount(tp,LOCATION_MZONE))
	if Duel.NegateAttack() and ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,511009746,0x581,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND) then
		Duel.BreakEffect()
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local ct=ft
		if ft>1 then
			local selct = {}
			for i=1,ft do selct[i]=i end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(15341821,0))
			ct=Duel.AnnounceNumber(tp,table.unpack(selct))
		end
		for i=1,ct do
			local token=Duel.CreateToken(tp,511009746)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		Duel.SpecialSummonComplete()
	end
end
