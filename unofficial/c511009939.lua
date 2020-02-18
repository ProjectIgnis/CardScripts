--Salamangreat Sparks
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)	
	--token
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tokencon)
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsLinkMonster() and c:IsRace(RACE_CYBERSE)
end
function s.atkcon(e)
	local eq=e:GetHandler():GetEquipTarget()
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and (Duel.GetAttacker()==eq or Duel.GetAttackTarget()==eq) and Duel.GetAttackTarget()~=nil 
end
function s.atkval(e,c)
	local eq=e:GetHandler():GetEquipTarget()
	return eq:GetBattleTarget():GetAttack()
end


function s.tokencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) 
		and c:CheckUniqueOnField(tp)
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local ct=2
		for p=0,1 do
			if Duel.GetLocationCount(p,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x119,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,p) then return true end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,PLAYER_ALL,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,0,PLAYER_ALL,0)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local ct=2
	if ct==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLEUEYES_SPIRIT) then ct=1 end
	repeat
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x119,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,tp)
		local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x119,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE,1-tp)
		if not (b1 or b2) then break end
		local op=0
		if b1 and b2 then
			op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
		elseif b1 then
			op=Duel.SelectOption(tp,aux.Stringid(id,1))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
		end
		local p=tp
		if op>0 then p=1-tp end
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,p,false,false,POS_FACEUP_DEFENSE)
		ct=ct-1
	until ct==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0))
	Duel.SpecialSummonComplete()
end
