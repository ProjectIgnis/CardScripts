--No.48 シャドー・リッチ (Manga)
--Number 48: Shadow Lich (Manga)
Duel.LoadCardScript("c21521304.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 3 monsters
	Xyz.AddProcedure(c,nil,3,2)
	--Cannot be destroyed by battle, except with a "Number" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--If this card is targeted for an attack, or would be destroyed or banished by an opponent's card, Special Summon "Phantom Tokens" instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.replacetg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.replacetg)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.replacetg)
	e4:SetValue(s.repval)
	c:RegisterEffect(e4)
	--You take no battle damage from battles involving "Phantom Tokens"
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsCode,1426715))
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Gains ATK equal to the total ATK of all "Phantom Tokens" you control
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(s.atkcon)
	e6:SetOperation(s.atkop)
	c:RegisterEffect(e6)
	--Return this card to its original form if it's in the End Phase or if it leaves the field
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e7:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) e:GetHandler():Recreate(511015118) end)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetCode(EVENT_LEAVE_FIELD_P)
	e8:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e8:SetOperation(s.leaveop)
	c:RegisterEffect(e8)
end
s.listed_series={SET_NUMBER}
s.listed_names={1426715} --"Phantom Token"
s.xyz_number=48
function s.mvfilter(c)
	return c:HasFlagEffect(id) and c:GetSequence()<5
end
function s.replacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) end
	if chk==0 then return not c:HasFlagEffect(id) and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()==1-tp 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511015218,0,TYPES_TOKEN,500,500,3,RACE_FIEND,ATTRIBUTE_DARK) end
	local g=c:GetOverlayGroup()
	if #g>0 then 
		Duel.SendtoGrave(g,REASON_RULE)
	end
	c:Recreate(511015218,1426715,nil,TYPES_TOKEN,3,ATTRIBUTE_DARK,RACE_FIEND,500,500,nil,nil,false)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END,0,1)
	local tg=Group.FromCards(c)
	for i=1,ft do
		local token=Duel.CreateToken(tp,511015218,TYPES_TOKEN,500,500,3,RACE_FIEND,ATTRIBUTE_DARK)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		token:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END,0,1)
		tg:AddCard(token)
		--You take no battle damage from battles involving this Token
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1)
		--Inflict damage to your opponent when this Token is destroyed
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_DAMAGE)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_LEAVE_FIELD)
		e2:SetOperation(s.damop)
		token:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	local sg=Duel.GetMatchingGroup(s.mvfilter,tp,LOCATION_MZONE,0,nil)
	for tc in sg:Iter() do
		Duel.HintSelection(Group.FromCards(tc))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)		
		local zone=Duel.SelectFieldZone(tp,1,LOCATION_MZONE,0,ZONES_EMZ)
		local seq=math.log(zone>>8,2)
		local oc=Duel.GetFieldCard(tp,LOCATION_MZONE,seq)
		if oc then
			Duel.SwapSequence(tc,oc)
		else
			Duel.MoveSequence(tc,seq)
		end
	end
	return true
end
function s.repval(e,c)
	if c:GetDestination()==LOCATION_REMOVED then return true
	else return false end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		local atk=c:GetPreviousAttackOnField()
		Duel.Damage(1-c:GetPreviousControler(),atk,REASON_EFFECT)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,1426715)
		and not e:GetHandler():HasFlagEffect(id)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,1426715)
	if #g>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(g:GetSum(Card.GetAttack))
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:Recreate(511015118)
	Duel.AdjustInstantly(c)
end