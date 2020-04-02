--魔救の奇石－ラプタイト
--Adamancipator Crystal - Raptite
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--decktop other
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dtcon)
	e1:SetTarget(s.dttg)
	e1:SetOperation(s.dtop)
	c:RegisterEffect(e1)
	--to extra
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={0x140}
function s.dtcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x140)
end
function s.dtfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToDeck()
end
function s.dttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dtfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.dtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.dtfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
		if not tc:IsLocation(LOCATION_EXTRA) then
			Duel.ConfirmDecktop(tp,1)
		end
	end
end
function s.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtra()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) and c:IsAbleToDeck() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,LOCATION_GRAVE)
	if tc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tp,0)
	end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
		and c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,0,REASON_EFFECT)~=0 then
		Duel.ConfirmDecktop(tp,1)
	end
end
