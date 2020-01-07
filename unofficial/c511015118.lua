--Number 48: Shadow Lich (Manga)

local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	--battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)
	-- summon tokens
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)	
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.con)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
s.listed_series={0x48}
s.listed_names={1426715}
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0
		and not c:IsReason(REASON_REPLACE) and c:GetReasonPlayer()~=tp 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_TOKEN,500,500,3,RACE_FIEND,ATTRIBUTE_DARK) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
		
	local g=c:GetOverlayGroup()
	Duel.SendtoGrave(g,REASON_RULE)
	
	local pos = POS_FACEUP_DEFENSE
	if c:IsPosition(POS_ATTACK) then pos=POS_FACEUP_ATTACK end
	
	Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	
	--change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(1426715)
	c:RegisterEffect(e1)
	--change atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--change def
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_BASE_DEFENSE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	--token type
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e4:SetValue(TYPE_TOKEN)
	c:RegisterEffect(e4)
	
	local tg=Group.FromCards(c)	
	while Duel.GetLocationCount(tp,LOCATION_MZONE)>0 do
		local token=Duel.CreateToken(tp,id,TYPES_TOKEN,500,500,3,RACE_FIEND,ATTRIBUTE_DARK)	
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)		
		tg:AddCard(token)
		
		token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		
		--change name
		local e1b=e1:Clone()
		e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		token:RegisterEffect(e1b)
		--change atk
		local e2b=e2:Clone()
		e2b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		token:RegisterEffect(e2b)
		--change def
		local e3b=e3:Clone()
		e3b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		token:RegisterEffect(e3b)
		--token type
		local e4b=e4:Clone()
		e4b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		token:RegisterEffect(e4b)
		--avoid battle damage
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e5:SetValue(1)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e5)
		--destroy damage
		local e6=Effect.CreateEffect(c)
		e6:SetCategory(CATEGORY_DAMAGE)
		e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e6:SetCode(EVENT_LEAVE_FIELD)
		e6:SetOperation(s.damop)
		token:RegisterEffect(e6)
	end
	Duel.ShuffleSetCard(tg)		
	Duel.ChangePosition(tg,pos)
	return true
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		local d=c:GetPreviousAttackOnField()
		Duel.Damage(1-c:GetPreviousControler(),d,REASON_EFFECT)
	end
	Duel.SendtoDeck(c,nil,-2,REASON_RULE)
	e:Reset()
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,1426715)
		and e:GetHandler():GetFlagEffect(id)==0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,1426715)
	if #g>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(g:GetSum(Card.GetAttack))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end