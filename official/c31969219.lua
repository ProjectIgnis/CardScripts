--影の災い
--Shadow Trouble
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Apply effect to an opponent's monster based on the number of cards with its name in their GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,tp)
	if c:IsFacedown() then return false end
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,0,LOCATION_GRAVE,nil,c:GetCode())
	if ct==0 then return false end
	if ct==1 then return true end
	if ct==2 then return c:IsAbleToRemove() end
	return c:IsAbleToRemove(tp,POS_FACEDOWN) and Duel.IsExistingMatchingCard(s.rmfdfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,c,tp,c:GetCode())
end
function s.rmfdfilter(c,tp,...)
	return c:IsFaceup() and c:IsCode(...) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp):GetFirst()
	local gg=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_GRAVE,nil,tc:GetCode())
	local ct=#gg
	if ct==1 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	elseif ct==2 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,tp,0)
	elseif ct>=3 then
		local rg=Duel.GetMatchingGroup(s.rmfdfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,tp,tc:GetCode())
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local gg=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_GRAVE,nil,tc:GetCode())
	local ct=#gg
	if ct==1 then
		--Destroy it
		Duel.Destroy(tc,REASON_EFFECT)
	elseif ct==2 then
		--Banish it
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	elseif ct>=3 then
		--Banish it, also all cards with that name from your opponent's field and GY, face-down
		local rg=Duel.GetMatchingGroup(s.rmfdfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil,tp,tc:GetCode())+tc
		if #rg>0 then
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end