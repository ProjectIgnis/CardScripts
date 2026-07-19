--グリズリーファザー
--Father Grizzly
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When this card is destroyed by battle and sent to the GY: You can Special Summon 1 Level 4 monster with 1400 ATK from your Deck, or if you have 2 or more Level 4 monsters with 1400 ATK in your GY, you can Special Summon 1 Normal Monster instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(function(e)
		return e:GetHandler():IsLocation(LOCATION_GRAVE)
	end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--When your opponent activates a monster effect and you control a face-up non-Effect Monster (Quick Effect): You can banish this card from your GY; negate the activation, and if you do, destroy that monster. You can only use this effect of "Father Grizzly" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ep==1-tp and re:IsMonsterEffect() and Duel.IsChainNegatable(ev)
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsNonEffectMonster),tp,LOCATION_MZONE,0,1,nil)
	end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		local rc=re:GetHandler()
		Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
		if rc:IsDestructable() and rc:IsRelateToEffect(re) then
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
		end
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end)
	c:RegisterEffect(e2)
end
function s.normalspconfilter(c)
	return c:IsLevel(4) and c:IsAttack(1400)
end
function s.spfilter(c,e,tp,normal_chk)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsLevel(4) and c:IsAttack(1400))
		or (normal_chk and c:IsType(TYPE_NORMAL)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local normal_chk=Duel.IsExistingMatchingCard(s.normalspconfilter,tp,LOCATION_GRAVE,0,2,nil)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,normal_chk)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local normal_chk=Duel.IsExistingMatchingCard(s.normalspconfilter,tp,LOCATION_GRAVE,0,2,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,normal_chk)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end