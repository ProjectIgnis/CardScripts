--増殖するクリボー！
--Multiplying Kuriboh!
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a monster effect, or an opponent's monster declares an attack (Quick Effect): You can Special Summon this card from your hand
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetType(EFFECT_TYPE_QUICK_O)
	e1a:SetCode(EVENT_CHAINING)
	e1a:SetRange(LOCATION_HAND)
	e1a:SetCountLimit(1,id)
	e1a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp and re:IsMonsterEffect() end)
	e1a:SetTarget(s.selfsptg)
	e1a:SetOperation(s.selfspop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1b:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	c:RegisterEffect(e1b)
	--Once per turn, when your opponent activates a monster effect on the field, or during damage calculation, when an opponent's monster attacks (Quick Effect): You can add to your hand, or Special Summon, 1 "Dark Magician" or 1 monster with 300 ATK/200 DEF from your Deck or GY, then you can change that opponent's monster's ATK to 0
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2a:SetType(EFFECT_TYPE_QUICK_O)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp and re:IsMonsterEffect() and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&LOCATION_MZONE>0 end)
	e2a:SetTarget(s.thsptg)
	e2a:SetOperation(s.thspop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2b:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	c:RegisterEffect(e2b)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thspfilter(c,e,tp,mmz_chk)
	return (c:IsCode(CARD_DARK_MAGICIAN) or (c:IsAttack(300) and c:IsDefense(200))) and (c:IsAbleToHand()
		or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,mmz_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thspfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	if not sc then return end
	local res=aux.ToHandOrElse(sc,tp,
		function() return mmz_chk and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function() return Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,3)
	)
	if res==0 then return end
	if sc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp) end
	local opp_card=nil
	local relation_chk=false
	if not Duel.IsDamageStep() then
		opp_card=re:GetHandler()
		relation_chk=opp_card:IsRelateToEffect(re)
	else
		opp_card=Duel.GetAttacker()
		relation_chk=opp_card:IsRelateToBattle()
	end
	if relation_chk and opp_card:IsFaceup() and opp_card:IsControler(1-tp) and not opp_card:IsAttack(0)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.BreakEffect()
		--Change that opponent's monster's ATK to 0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		opp_card:RegisterEffect(e1)
	end
end