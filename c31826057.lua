--音響戦士ピアーノ
local s,id=GetID()
function s.initial_effect(c)
	--race change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x1066}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066) and c:IsLevelAbove(1)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL-g:GetFirst():GetRace())
	--Duel.SetTargetParam(rc)
	e:SetLabel(rc)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL-g:GetFirst():GetRace())
	--Duel.SetTargetParam(rc)
	e:SetLabel(rc)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	--local rc=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local rc=e:GetLabel()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(rc)
		tc:RegisterEffect(e1)
	end
end