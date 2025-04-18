--ネフティスの繋ぎ手
--Conductor of Nephthys
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon 1 "Nephthys" Ritual from your hand/Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsRitualSummoned() end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Register if Tributed by a "Nephthys" card's effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.regcond)
	e2:SetTarget(s.regtg)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--Register if destroyed by a "Nephthys" card's effect
	local e3=e2:Clone()
	e3:SetCode(EVENT_DESTROYED)
	c:RegisterEffect(e3)
end
s.listed_names={23459650,id}
s.listed_series={SET_NEPHTHYS}
function s.spfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_RITUAL)
	return #pg<=0 and c:IsSetCard(SET_NEPHTHYS) and c:IsRitualMonster() and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
function s.regcond(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(SET_NEPHTHYS) and r&REASON_EFFECT>0
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.IsPhase(PHASE_STANDBY) and 2 or 1
	--Destroy up to 3 "Nephthys" cards from your hand/Deck/field
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descond)
	e1:SetOperation(s.desop)
	e1:SetLabel(ct,Duel.GetTurnCount())
	e1:SetReset(RESET_PHASE|PHASE_STANDBY,ct)
	Duel.RegisterEffect(e1,tp)
end
function s.desfilter(c,e)
	return c:IsSetCard(SET_NEPHTHYS) and c:IsDestructable(e) and not c:IsRitualMonster() and (c:IsFaceup() or not c:IsLocation(LOCATION_ONFIELD))
end
function s.descond(e,tp,eg,ep,ev,re,r,rp)
	local sp_label,turn=e:GetLabel()
	return (sp_label==1 or turn~=Duel.GetTurnCount()) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD,0,1,nil,e)
end
function s.descheck(sg,e,tp,mg)
	local res=sg:GetClassCount(Card.GetLocation)==#sg
	return res,not res
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD,0,nil,e)
	if #sg==0 then return end
	local rg=aux.SelectUnselectGroup(sg,e,tp,1,3,s.descheck,1,tp,HINTMSG_DESTROY)
	Duel.Destroy(rg,REASON_EFFECT)
	e:Reset()
end