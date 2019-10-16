--死配の呪眼
--Death Control of the Evil Eye
local s,id = GetID()
function s.initial_effect(c)
	--activate and use effect
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--control
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_CONTROL)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	e3:SetValue(s.tg)
	c:RegisterEffect(e3)
	--treats
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ADD_SETCODE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(aux.PersistentTargetFilter)
	e4:SetCondition(s.sccon)
	e4:SetValue(0x129)
	c:RegisterEffect(e4)
	--destroy
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.descon)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.listed_series={0x129}
s.listed_names={CARD_EVIL_EYE_SELENE}
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
function s.cfilter2(c,e,tp,eg)
	return c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and c:IsControlerCanBeChanged() and c:IsPosition(POS_FACEUP_ATTACK)
		and eg:IsExists(s.cfilter3,1,nil,c:GetAttack())
end
function s.cfilter3(c,atk)
	return c:GetAttack()>atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_MZONE,0,nil)
	if chkc then return s.cfilter2(chkc,e,tp,g) and eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(s.cfilter2,1,nil,e,tp,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tg=eg:FilterSelect(tp,s.cfilter2,1,1,nil,e,tp,g)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tg,1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
	if c:IsRelateToEffect(re) and tc and tc:IsRelateToEffect(re) then
		c:SetCardTarget(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_OWNER_RELATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetCondition(s.con)
		tc:RegisterEffect(e1)
	end
end
function s.con(e)
	local c=e:GetOwner()
	local h=e:GetHandler()
	return c:IsHasCardTarget(h)
end
function s.tg(e,c)
	return e:GetHandlerPlayer()
end
function s.sccon(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_EVIL_EYE_SELENE),e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
