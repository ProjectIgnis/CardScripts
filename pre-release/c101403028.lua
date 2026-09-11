--リインゼルム・ギリアカルマ
--Reindsurm Giriakarma
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--When your opponent activates a monster effect in the field or GY and you control this Ritual Summoned card (Quick Effect): You can negate the activation, then you can shuffle 1 monster each from both your opponent's field and GY into the Deck, also if either of them was a Dragon monster, double this card's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ep==1-tp and re:IsMonsterEffect() and Chain.IsTriggeringLocation(ev,LOCATION_MZONE|LOCATION_GRAVE)
			and e:GetHandler():IsRitualSummoned() and Chain.IsNegatable(ev)
	end)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--If this card and a LIGHT "Reindsurm" monster are in your GY: You can add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.selfthcon)
	e2:SetTarget(s.selfthtg)
	e2:SetOperation(s.selfthop)
	c:RegisterEffect(e2)
end
s.listed_names={101403055} --"Reindsurm Conquest"
s.listed_series={SET_REINDSURM}
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,2,1-tp,LOCATION_MZONE|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.NegateActivation(ev) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.AND(Card.IsMonster,Card.IsAbleToDeck)),tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil)
	if #g>=2 and g:GetClassCount(Card.GetLocation)==2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetLocation),1,tp,HINTMSG_TODECK)
		if #sg~=2 then return end
		local dragon_chk=sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON)
		Duel.HintSelection(sg)
		Duel.BreakEffect()
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if not dragon_chk then return end
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Also if either of them was a Dragon monster, double this card's ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(c:GetAttack()*2)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
function s.selfthconfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(SET_REINDSURM)
end
function s.selfthcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.selfthconfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.selfthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.selfthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end