--拡散光波
--Double Exposure
--Scripted by Eerie Code, based on the anime version
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--double level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	--name change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetTarget(s.nmtg)
	e3:SetOperation(s.nmop)
	c:RegisterEffect(e3)	
end
s.listed_series={0xe5}
function s.lvfilter(c,e)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsCanBeEffectTarget(e)
end
function s.lvcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.lvcheck,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.lvcheck,1,tp,HINTMSG_FACEUP)
	Duel.SetTargetCard(sg)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	for tc in aux.Next(tg) do
		--Double their Levels
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		e1:SetValue(tc:GetLevel()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.nmfilter2(c,cd)
	return c:IsFaceup() and not c:IsCode(cd)
end
function s.nmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe5) 
		and Duel.IsExistingMatchingCard(s.nmfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetCode())
end
function s.nmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.nmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.nmfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.nmfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.nmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=Duel.SelectMatchingCard(tp,s.nmfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc,tc:GetCode())
	if #sg>0 then
		Duel.HintSelection(sg)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetCode())
		sg:GetFirst():RegisterEffect(e1)
	end
end