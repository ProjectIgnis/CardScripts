-- 嵐闘機ストームライダーガーゴイリード
--Stormrider Gargoyle
--Scripted by Belisk
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69488544,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.actcon)
	e1:SetCost(s.actcost)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetCode(4179255)
	c:RegisterEffect(e1a)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.actcon2)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.acttg2)
	e2:SetOperation(s.actop2)
	c:RegisterEffect(e2)
end
s.listed_series={0x580}
s.listed_names={511600232}
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsActiveType(TYPE_FIELD)
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_HAND) and c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.actfilter(c,tp)
	return c:IsCode(511600232) and c:GetActivateEffect():IsActivatable(tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.actfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48934760,0))
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.actfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FIELD) and c:IsSetCard(0x580) and c:IsAbleToGrave()
end
function s.actcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_FZONE,0,1,nil)
end
function s.actfilter2(c,e,tp,code)
	return c:IsSetCard(0x580) and c:IsType(TYPE_FIELD) 
		and (c:IsAbleToHand() or c:GetActivateEffect():IsActivatable(tp)) and c:GetOriginalCode()~=code
end
function s.acttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_FZONE,0,nil)
  	local code=g:GetFirst():GetOriginalCode() 
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_FZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.actfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,code) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.actop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_FZONE,0,1,1,nil):GetFirst()
	if tg and Duel.SendtoGrave(tg,REASON_EFFECT)~=0 and tg:IsLocation(LOCATION_GRAVE) then
		local code=tg:GetOriginalCode()
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(89208725,0))
		local g=Duel.SelectMatchingCard(tp,s.actfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
		local tc=g:GetFirst()
		if tc then
			local te=tc:GetActivateEffect()
			local b1=tc:IsAbleToHand()
			local b2=te:IsActivatable(tp)
			if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(89208725,1))) then
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc)
			else
				aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end