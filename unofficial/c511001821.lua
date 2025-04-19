--ネクロイド・シンクロ (Manga)
--Necroid Synchro (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--synchro effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sctg)
	e1:SetOperation(s.scop)
	c:RegisterEffect(e1)
end
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_GRAVE,0,nil)
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_GRAVE,0,nil)
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		Synchro.Send=2
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetOperation(s.regop)
		sc:RegisterEffect(e1)
		Duel.SynchroSummon(tp,sc,nil,mg)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetOwner()
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(rc)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2,true)
	e:Reset()
end