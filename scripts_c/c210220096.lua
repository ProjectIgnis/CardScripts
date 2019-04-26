--ネメシスフュージョン
--Nemesis Fusion
--Created and scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_FUSION_SUMMON)
	local se=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	return ep~=tp and (ex or re:IsHasCategory(CATEGORY_FUSION_SUMMON))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		or Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE)) end
	if not Duel.IsPlayerAffectedByEffect(tp,EFFECT_DISCARD_COST_CHANGE) then
		Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then Duel.ConfirmCards(tp,g) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	s.announce_filter={TYPE_FUSION,OPCODE_ISTYPE }
	local ac=Duel.AnnounceCardFilter(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.filter(c,e,tp,m,f,chkf)
	return (not f or f(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false,POS_FACEUP,1-tp)
		and c:CheckFusionMaterial(m,nil,chkf)
end
function s.matfilter(c,e)
	return c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD) and (c:IsFaceup() or not c:IsLocation(LOCATION_ONFIELD)) and not c:IsImmuneToEffect(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g<1 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local sg=g:FilterSelect(1-tp,Card.IsCode,1,1,nil,ac)
	local tc=sg:GetFirst()
	if not tc then 
		Duel.ConfirmCards(tp,g)
		return 
	end
	Duel.ConfirmCards(tp,sg)
	if not Duel.NegateEffect(ev) then return end
	local chkf=1-tp
	local mg1=Duel.GetFusionMaterial(1-tp):Filter(s.matfilter,nil,e)
	if s.filter(tc,e,1-tp,mg1,nil,chkf) then
		local mat1=Duel.SelectFusionMaterial(1-tp,tc,mg1,nil,chkf)
		tc:SetMaterial(mat1)
		Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.BreakEffect()
		local pos=0
		local op=0
		local a=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,1-tp,false,false,POS_FACEUP_ATTACK,tp)
		local d=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,1-tp,false,false,POS_FACEUP_DEFENSE,tp)
		if a and d then
			op=Duel.SelectOption(tp,1156,1155)
		elseif a then
			op=Duel.SelectOption(tp,1156)
		else
			op=Duel.SelectOption(tp,1155)+1
		end
		if op==0 then pos=POS_FACEUP_ATTACK else pos=POS_FACEUP_DEFENSE end
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,1-tp,tp,false,false,pos)
	end
end
