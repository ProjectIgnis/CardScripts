--王の憤激
--Generaider Boss Bite
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x134}
function s.check(sg,tp,exg)
	return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,sg,sg,tp)
end
function s.filter(c,sg,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,#sg,sg,c)
end
function s.matfilter(c,tc)
	return c:IsSetCard(0x134) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TOKEN)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c~=tc
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,s.check,nil,0x134) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,99,false,s.check,nil,0x134)
	Duel.Release(g,REASON_COST)
	local og=Duel.GetOperatedGroup()
	og:KeepAlive()
	e:SetLabelObject(og)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,g,tp) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,g,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=e:GetLabelObject()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and rg and #rg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,#rg,#rg,rg,tc)
		if #g>0 then
			for tc in aux.Next(g) do
				local og=tc:GetOverlayGroup()
				if #og>0 then
					Duel.SendtoGrave(og,REASON_RULE)
				end
				tc:CancelToGrave()
			end
			Duel.Overlay(tc,g)
		end
	end
end
