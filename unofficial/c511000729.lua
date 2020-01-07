--Berserk Mode
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
	local ct=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetCount()
	local atk=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil):RandomSelect(tp,ct)
	local tc1=atk:GetFirst()
	while tc1 do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_CHAIN)
		e1:SetValue(1)
		tc1:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetReset(RESET_CHAIN)
		e2:SetValue(1)
		tc1:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetReset(RESET_CHAIN)
		e3:SetValue(1)
		tc1:RegisterEffect(e3)
		tc1=atk:GetNext()
	end
	tc1=atk:GetFirst()
	while tc1 do
		local def=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,tc1):RandomSelect(tp,ct-1)
		local tc2=def:GetFirst()
		while tc2 do
			Duel.CalculateDamage(tc1,tc2)
			if tc1:GetAttack()>tc2:GetAttack() then
				tc2:RegisterFlagEffect(id,RESET_CHAIN,0,1)
				local dif=tc1:GetAttack()-tc2:GetAttack()
				Duel.Damage(tc2:GetControler(),dif,REASON_BATTLE)
				Duel.RaiseSingleEvent(tc1,EVENT_BATTLE_DAMAGE,e,REASON_EFFECT,0,1-tp,dif)
			elseif tc1:GetAttack()<tc2:GetAttack() then
				tc1:RegisterFlagEffect(id,RESET_CHAIN,0,1)
				local dif=tc2:GetAttack()-tc1:GetAttack()
				Duel.Damage(tc1:GetControler(),dif,REASON_BATTLE)
				Duel.RaiseSingleEvent(tc2,EVENT_BATTLE_DAMAGE,e,REASON_EFFECT,0,1-tp,dif)
			else
				tc1:RegisterFlagEffect(id,RESET_CHAIN,0,1)
				tc2:RegisterFlagEffect(id,RESET_CHAIN,0,1)
			end
			tc2=def:GetNext()
		end
		tc1=atk:GetNext()
	end
	local des=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Destroy(des,REASON_BATTLE)
end
function s.desfilter(c)
	return c:GetFlagEffect(id)>0
end
