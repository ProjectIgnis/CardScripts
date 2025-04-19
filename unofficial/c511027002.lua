--聖天樹の灰樹精 (Anime)
--Sunavalon Melias (Anime)
--Scripted by Playmaker 772211
--Fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),2,nil,s.matcheck)
	--Cannot be link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(s.matcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Special summon a normal plant
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Cannot be attack target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Multi Attacks
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.atcon)
	e4:SetTarget(s.attg)
	e4:SetOperation(s.atop)
	c:RegisterEffect(e4)
end
s.listed_series={0x2157,0x1157}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,1,nil,TYPE_LINK,lc,sumtype,tp)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLinkSummoned() and c:GetTurnID()==Duel.GetTurnCount()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLinkSummoned()
end
function s.sfilter(c,e,tp,zone)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone&0x1f)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp,e:GetHandler():GetLinkedZone(tp)) end
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone&0x1f) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone&0x1f)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if zone==0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone&0x1f)
	end
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.atfilter(c,lg)
	return c:IsSetCard(SET_SUNVINE) and c:IsLinkMonster() and lg and lg:IsContains(c)
end
function s.valfilter(c)
	return c:IsSetCard(SET_SUNAVALON) and c:IsLinkMonster()
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atfilter(chkc,e:GetHandler():GetLinkedGroup()) end
	local lg=e:GetHandler():GetLinkedGroup()
	if chk==0 then return Duel.IsExistingTarget(s.atfilter,tp,LOCATION_MZONE,0,1,nil,lg)
		and Duel.GetMatchingGroupCount(s.valfilter,tp,LOCATION_MZONE,0,nil)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	local ct=Duel.GetMatchingGroupCount(s.valfilter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		--Can make additional attacks this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		e1:SetValue(ct-1)
		tc:RegisterEffect(e1)
	elseif ct==0 then
		--Cannot attack this turn if there are no "Sunavalon" Link Monsters when this effect resovles
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e2)
	end
end