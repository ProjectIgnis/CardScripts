--破壊剣士の守護絆竜
--Companion Whelp of the Destruction Swordsman
--Logical Nonsense

--Substitute ID
local s,id=GetID()

function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2)
	--Upon link summon, send 1 "Destruction Sword" from deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--End of Battle Phase, if opponent has no monsters, burn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1,id+1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.dmgcon)
	e2:SetTarget(s.dmgtg)
	e2:SetOperation(s.dmgop)
	c:RegisterEffect(e2)
end
	--Related to "Destruction Sword" archetype
s.listed_series={0xd6,0xd7}

	--Check for "Destruction Sword" card to send to GY
function s.tgfilter(c)
	return c:IsSetCard(0xd6) and c:IsAbleToGrave()
end
	--Check for "Buster Blader" monster
function s.filter(c,e,tp)
	return c:IsSetCard(0xd7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	--If link summoned
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
	--Activation legality
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_HAND)
end
	--Send 1 "Destruction Sword" to GY, then can special summon "Buster Blader" monster from hand
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	local g2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g1>0 and Duel.SendtoGrave(g1,REASON_EFFECT)~=0 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g3=g2:Select(tp,1,1,nil)
		Duel.SpecialSummon(g3,0,tp,tp,false,false,POS_FACEUP)
	end
end
	--If it's player's Battle Phase and opponent has no monsters
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
	--Check for "Buster Blader" monster that didn't attack
function s.dmgfilter(c)
	return c:GetAttackAnnouncedCount()==0 and c:IsFaceup() and c:IsSetCard(0xd7)
end
	--Activation legality
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.dmgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.dmgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.dmgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack())
end
	--Burn equal to a "Buster Blader" monster's ATK
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end

