--ニュートリノ・ダウジング
--Neutrino Dowsing
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GALAXY_EYES}
function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsControler(1-tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_GALAXY_EYES) and c:GetOverlayCount()>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local xyzc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.HintSelection(xyzc,true)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
	local g=xyzc:GetOverlayGroup():Select(tp,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tgfilter(c)
	return c:IsNormalSpell() and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		local te,eg,ep,ev,re,r,rp=tc:CheckActivateEffect(false,true,false)
		if not (te and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
		e:SetLabelObject(te)
		Duel.ClearTargetCard()
		local tg=te:GetTarget()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end