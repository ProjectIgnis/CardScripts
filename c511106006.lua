--産卵床
--Egg Clutch
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--change pos
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetOperation(s.deschk)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--token
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCost(s.cos)
	e5:SetTarget(s.target)
	e5:SetOperation(s.activate)
	c:RegisterEffect(e5)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsControler(tp)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.posfilter(c)
	return c:IsType(TYPE_MONSTER) and c:GetSequence()<=4 and not c:IsPosition(POS_FACEUP_DEFENSE)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.posfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPDEFENSE)
	local sg=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
	if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		e:GetHandler():CreateRelation(tc,RESET_EVENT+RESETS_STANDARD)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.relcon)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RACE_INSECT)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e4)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
function s.relcon(e)
	return e:GetOwner():IsRelateToCard(e:GetHandler())
end
function s.deschk(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst() local des=0
	while tc do
	if tc:GetFlagEffect(id)~=0 then des=des+1 end
	tc=eg:GetNext()
	end
	if des>0 then e:GetHandler():RegisterFlagEffect(id+100,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+100)~=0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	e:GetHandler():ResetFlagEffect(id+100)
end
function s.costfilter(c)
	return c:IsRace(RACE_INSECT) 
end
function s.cos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,false,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,false,nil)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009659,(0x3e|0x537),TYPES_TOKEN,0,0,1,RACE_INSECT,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) end
	local tk=2
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then tk=1 end
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,tk,0,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,tk,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,511009659,(0x3e|0x537),TYPES_TOKEN,0,0,1,RACE_INSECT,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE,1-tp) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft~=1 then
		local ct = {}
		for i=1,math.min(ft,2) do
			ct[#ct+1]=i
		end
		ft=Duel.AnnounceNumber(tp,table.unpack(ct))
	end
	for i=1,ft do
		local token=Duel.CreateToken(tp,511009659)
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
