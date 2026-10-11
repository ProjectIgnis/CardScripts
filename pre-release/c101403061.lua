--神幻学都アルス＝マグナ
--Ars Magna Academic Arcane Apparition Acropolis
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Your activated "Medius" monsters' effects cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetValue(function(e,ct)
		return Chain.IsTriggeringPlayer(ct,e:GetHandlerPlayer())
			and Chain.IsTriggeringSetcode(ct,SET_MEDIUS)
			and Chain.IsTriggeringType(ct,TYPE_MONSTER)
	end)
	c:RegisterEffect(e1)
	--If you have a "Power Patron" monster in your GY: You can banish 1 Fusion, Synchro, or Xyz Monster from your GY, and declare 1 "Ars Magna" Link Monster Card name that has not been declared for "Ars Magna Academic Arcane Apparition Acropolis" this turn; Special Summon that monster from your Extra Deck, but it cannot be used as Link Material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Track names declared to activate e2
	aux.GlobalCheck(s,function()
		s.declared_names={}
		s.declared_names[0]={}
		s.declared_names[1]={}
		aux.AddValuesReset(function()
			s.declared_names={}
			s.declared_names[0]={}
			s.declared_names[1]={}
		end)
	end)
end
s.listed_series={SET_ARTMAGE,SET_MEDIUS,SET_POWER_PATRON,SET_ARS_MAGNA}
function s.spconfilter(c)
	return c:IsSetCard(SET_POWER_PATRON) and c:IsMonster()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.spcostfilter(c,tp)
	return c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
		and Duel.GetLocationCountFromEx(tp,tp,c,TYPE_LINK)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.declfilter(c,e,tp,names_already_declared)
	return c:IsSetCard(SET_ARS_MAGNA) and c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,tp,false,false)
		and not c:IsCode(names_already_declared)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.declfilter,tp,LOCATION_EXTRA,0,nil,e,tp,s.declared_names[tp])
	if chk==0 then return #g>0 end
	s.announce_filter={}
	for _,code in ipairs(g:GetClass(Card.GetCode)) do
		if #s.announce_filter==0 then
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
		else
			table.insert(s.announce_filter,code)
			table.insert(s.announce_filter,OPCODE_ISCODE)
			table.insert(s.announce_filter,OPCODE_OR)
		end
	end
	local declared_card=Duel.AnnounceCard(tp,s.announce_filter)
	e:GetChainData().declared_card=declared_card
	table.insert(s.declared_names[tp],declared_card)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsLinkMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetChainData().declared_card
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		--Cannot be used as Link Material
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3312)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end