--帝王の開岩
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--spsummon limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.filter(c,code)
	return (c:GetAttack()==2400 or c:GetAttack()==2800) and c:GetDefense()==1000 and c:GetCode()~=code and c:IsAbleToHand()
end
function s.filter2(c,atk,code)
	return c:GetAttack()==atk and c:GetDefense()==1000 and c:GetCode()~=code and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,eg:GetFirst():GetCode()) end
	local t1=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,2400,eg:GetFirst():GetCode())
	local t2=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,2800,eg:GetFirst():GetCode())
	if t1 and t2 then e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)))
	elseif t1 then e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,1)))
	else e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,2))+1) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	eg:GetFirst():CreateEffectRelation(e)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ec=eg:GetFirst()
	if ec:IsFacedown() or not ec:IsRelateToEffect(e) then return end
	local atk=e:GetLabel()==0 and 2400 or 2800
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,atk,ec:GetCode())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
