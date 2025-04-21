--ティマイオスの眼
--The Eye of Timaeus
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Dragon Type Normal monster from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={1784686,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL} --The Eye of Timaeus
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(1784686) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end
function s.matfilter(c,e,tp,code)
	return s.tgfilter(c,e,tp) and c:IsCode(code)
end
function s.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL) and c:IsCanBeFusionMaterial()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,mc)
	if Duel.GetLocationCountFromEx(tp,tp,mc,c)<=0 then return false end
	local mustg=aux.GetMustBeMaterialGroup(tp,nil,tp,c,nil,REASON_FUSION)
	return c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(mc:GetCode()) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and (#mustg==0 or (#mustg==1 and mustg:IsContains(mc)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local sg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	local announceFilter={}
	for tc in sg:Iter() do
		if #announceFilter==0 then
			table.insert(announceFilter,tc:GetCode())
			table.insert(announceFilter,OPCODE_ISCODE)
		else
			table.insert(announceFilter,tc:GetCode())
			table.insert(announceFilter,OPCODE_ISCODE)
			table.insert(announceFilter,OPCODE_OR)
		end
		table.insert(announceFilter,OPCODE_ALLOW_ALIASES)
	end
	local code=Duel.AnnounceCard(tp,announceFilter)
	local tc=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,code):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=sg:GetFirst()
	if sc then
		sc:SetMaterial(Group.FromCards(tc))
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end