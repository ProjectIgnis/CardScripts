--Plunder Patroll Booty
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--change attr
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.costg)
	e2:SetOperation(s.cosop)
	c:RegisterEffect(e2)
	--to grave
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.gycon)
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
end
s.listed_series={0x13f}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if s.cost(e,tp,eg,ep,ev,re,r,rp,0) and s.costg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,94) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.cosop)
		s.cost(e,tp,eg,ep,ev,re,r,rp,1)
		s.costg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function s.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local att=Duel.AnnounceAttribute(tp,1,0xff-g:GetFirst():GetAttribute())
	Duel.SetTargetParam(att)
end
function s.filter(c,e,tp,ft)
	return c:IsSetCard(0x13f) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToDeck() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.cosop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	local att=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,nil,e,tp,ft)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local sc=g:Select(tp,1,1,nil):GetFirst()
			if ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not sc:IsAbleToDeck() or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			else
				Duel.SendtoDeck(sc,nil,2,REASON_EFFECT)
			end
		end
	end
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x13f),tp,LOCATION_MZONE,0,1,nil)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end

