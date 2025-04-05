--サイバネット・リフレッシュ
--Cynet Refresh
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Destroy all monsters in the Main Monster Zones
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Cyberse Link Monsters you control become unaffected
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.immcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.immop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	return ac:IsControler(1-tp) and ac:IsRace(RACE_CYBERSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,LOCATION_MMZONE)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MMZONE,LOCATION_MMZONE)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		for tc in og:Iter() do
			tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
		end
		--Special Summon destroyed Cyberse Link Monsters during the End Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(s.spcon)
		e1:SetOperation(s.spop)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.spfilter(c,e,tp)
	local owner=c:GetOwner()
	return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() and c:HasFlagEffect(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,owner)
		and Duel.GetLocationCount(owner,LOCATION_MZONE,tp)>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
	if #g==0 then return end
	local turn_p=Duel.GetTurnPlayer()
	local step=turn_p==0 and 1 or -1
	for p=turn_p,1-turn_p,step do
		local tg=g:Filter(Card.IsControler,nil,p)
		local lc=Duel.GetLocationCount(p,LOCATION_MZONE)
		if #tg>lc then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			tg=tg:Select(tp,lc,lc,nil)
		end
		for tc in tg:Iter() do
			Duel.SpecialSummonStep(tc,0,tp,p,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
end
function s.immfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() and c:IsFaceup()
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.immfilter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		--Unaffected by other cards' effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3100)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(function(e,re) return e:GetHandler()~=re:GetOwner() end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end