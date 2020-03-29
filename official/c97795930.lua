--幻煌龍の天渦
--Phantasm Spiral Assault
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfa}
s.listed_names={56649609,CARD_UMI}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(56649609)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(id)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		e0:SetValue(0)
		tc:RegisterEffect(e0)
		--win
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e1:SetCode(EVENT_BATTLE_DESTROYING)
		e1:SetCondition(s.wincon)
		e1:SetOperation(s.winop)
		e1:SetOwnerPlayer(tp)
		e1:SetLabelObject(e0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.winfilter(c)
	return c:IsSetCard(0xfa) and c:IsType(TYPE_EQUIP)
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.winfilter,nil)
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and g:GetClassCount(Card.GetCode)>2 and c:GetBattleTarget():IsType(TYPE_EFFECT)
		and c:GetControler()==e:GetOwnerPlayer()
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local value=te:GetValue()+1
	te:SetValue(value)
	e:GetOwner():SetTurnCounter(value)
	if value>2 then
		Duel.Win(tp,WIN_REASON_PHANTASM_SPIRAL)
	end
end
function s.handcon(e)
	return Duel.IsEnvironment(CARD_UMI)
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
