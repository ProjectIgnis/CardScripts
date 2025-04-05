--無千ジャミング
--Digit Jamming
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Change ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation(true))
	c:RegisterEffect(e2)
	--Change ATK/DEF on destruction
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetOperation(s.operation(false))
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(1000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.operation(check)
	return  function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local reset=0
				if check then
					if not c:IsRelateToEffect(e) then return end
					reset=RESET_EVENT|RESETS_STANDARD 
				else
					reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END 
				end
				local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
				for tc in g:Iter() do
					local atk=math.floor(tc:GetAttack()/1000)*1000
					local def=math.floor(tc:GetDefense()/1000)*1000
					--Change ATK/DEF
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_SET_ATTACK_FINAL)
					e1:SetValue(tc:GetAttack()-atk)
					e1:SetReset(reset)
					tc:RegisterEffect(e1)
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
					e2:SetValue(tc:GetDefense()-def)
					e2:SetReset(reset)
					tc:RegisterEffect(e2)
				end
			end
end