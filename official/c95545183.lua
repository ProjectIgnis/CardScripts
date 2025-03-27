--異譚の忍法帖
--Ninjitsu Art Notebook of Mystery
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Set 1 "Ninjitsu Art" Spell/Trap and/or 1 "Ninja" monster 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Change 1 face-up monster to face-down Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.poscond)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NINJA,SET_NINJITSU_ART}
s.listed_names={id}
function s.ninjitsu(c,zone_chk)
	return c:IsSetCard(SET_NINJITSU_ART) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id) and (zone_chk or c:IsType(TYPE_FIELD))
end
function s.ninja(c,e,tp)
	return c:IsSetCard(SET_NINJA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and not c:IsCode(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mzones=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local stzones=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then stzones=stzones-1 end
	if chk==0 then return Duel.IsExistingMatchingCard(s.ninjitsu,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,stzones>0)
		or (mzones>0 and Duel.IsExistingMatchingCard(s.ninja,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg and (sg:FilterCount(s.ninjitsu,nil,true)==1 or sg:FilterCount(s.ninja,nil,e,tp)==1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mzones=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g1=Group.CreateGroup()
	if mzones>0 then 
		g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ninja),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	end
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ninjitsu),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,true)
	g1:Merge(g2)
	if #g1==0 then return end
	local sg=aux.SelectUnselectGroup(g1,e,tp,1,2,s.rescon,1,tp,HINTMSG_TOFIELD)
	if #sg==0 then return end
	for tc in sg:Iter() do
		if tc:IsSpellTrap() then
			Duel.SSet(tp,tc,tp,false)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
	Duel.ConfirmCards(1-tp,sg)
end
function s.poscond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanTurnSet() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end