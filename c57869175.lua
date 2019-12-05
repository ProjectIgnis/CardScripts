--フォーチュンレディ・パスティー
--Fortune Lady Past
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--atk,def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	--increase own level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCondition(s.lvcon)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	--increase other level
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end
s.listed_series={0x31}
function s.atkval(e,c)
	return c:GetLevel()*200
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()==tp and c:HasLevel() and c:IsLevelBelow(11)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsLevelAbove(12) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
function s.rmfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToRemove() and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.lvfilter(c,tp)
	return c:IsFaceup() and c:HasLevel() and c:IsSetCard(0x31) and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND,0,1,c)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,529)
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local ch
	if tc:GetLevel()==1 then
		ch=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		ch=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	end
	local rg
	if ch==0 then
		rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,99,tc)
	elseif ch==1 then
		rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,tc:GetLevel()-1,tc)
	end
	if #rg>0 then
		local ct=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		if ct>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(ct)
			if tc==e:GetHandler() then
				e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			else
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			end
			if ch==1 then
				ct=-ct
			end
			e1:SetValue(ct)
			tc:RegisterEffect(e1)
		end
	end
end