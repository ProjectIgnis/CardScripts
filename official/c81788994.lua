--影牢の呪縛
--Curse of the Shadow Prison
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x16)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--atkdown
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--chain material
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHAIN_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.chcon)
	e4:SetTarget(s.chtg)
	e4:SetOperation(s.chop)
	e4:SetValue(aux.FilterBoolFunction(Card.IsSetCard,0x9d))
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetOperation(s.chk)
	e4:SetLabelObject(e5)
end
s.counter_place_list={0x16}
s.listed_series={0x9d}
function s.cfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.cfilter,nil)
	e:GetHandler():AddCounter(0x16,ct)
end
function s.atkcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function s.atkval(e,c)
	return e:GetHandler():GetCounter(0x16)*-100
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x16)>=3
end
function s.chfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsFaceup() or c:IsControler(tp)) and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.chtg(e,te,tp,value)
	if value&SUMMON_TYPE_FUSION==0 then return Group.CreateGroup() end
	return Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,te,tp)
end
function s.chop(e,te,tp,tc,mat,sumtype,sg)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	if mat:IsExists(Card.IsControler,1,nil,1-tp) then
		e:GetHandler():RemoveCounter(tp,0x16,3,REASON_EFFECT)
	end
	Duel.BreakEffect()
	if sg then
		sg:AddCard(tc)
	else
		Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,POS_FACEUP)
	end
end
function s.chk(tp,sg,fc)
	return sg:FilterCount(Card.IsControler,nil,1-tp)<=1
end
