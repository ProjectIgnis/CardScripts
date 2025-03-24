--武神隠
--Bujincident
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_BUJIN}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BUJIN) and c:IsType(TYPE_XYZ) and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local rct=Duel.GetTurnCount(tp)+1
	if Duel.IsTurnPlayer(1-tp) then rct=rct+1 end
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,0)
		local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 then Duel.SendtoHand(g,nil,REASON_EFFECT) end
		--trigger effect
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetCountLimit(1)
		e1:SetCondition(s.spresetcon)
		e1:SetTarget(s.sptg)
		e1:SetOperation(s.spop)
		e1:SetLabel(rct)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
		Duel.RegisterEffect(e1,tp)
	end
	--cannot summon/flip summon/sp summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e4,tp)
	--no damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetValue(0)
	e5:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	Duel.RegisterEffect(e5,tp)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e6:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	Duel.RegisterEffect(e6,tp)
	--player hint
	local e7=Effect.CreateEffect(e:GetHandler())
	e7:SetDescription(aux.Stringid(id,2))
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e7:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	e7:SetTargetRange(1,1)
	Duel.RegisterEffect(e7,tp)
	--reset e2~e7
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_PHASE+PHASE_END)
	e8:SetCountLimit(1)
	e8:SetCondition(s.spresetcon)
	e8:SetOperation(s.resetall)
	e8:SetLabel(rct)
	local reset_eff_table={e2,e3,e4,e5,e6,e7}
	e8:SetLabelObject(reset_eff_table)
	e8:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	Duel.RegisterEffect(e8,tp)
end
function s.resetall(e)
	local reset_eff_table=e:GetLabelObject()
	for _,eff in pairs(reset_eff_table) do
		eff:Reset()
	end
	e:Reset()
end
function s.spresetcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and e:GetLabel()==Duel.GetTurnCount(tp)
end
function s.mfilter(c)
	return c:IsSetCard(SET_BUJIN) and c:IsMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.mfilter(chkc) end
	if chk==0 then return true end
	local tc=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local mc=Duel.GetFirstTarget()
	if tc:GetFlagEffect(id)>0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and mc and mc:IsRelateToEffect(e) then
		Duel.Overlay(tc,mc)
	end
end