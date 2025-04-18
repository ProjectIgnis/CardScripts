--Ｔｈｅ ｓｕｐｐｒｅｓｓｉｏｎ ＰＬＵＴＯ
--The Suppression Pluto
local s,id=GetID()
function s.initial_effect(c)
	--announce
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.desfilter(c)
	return c:IsSpellTrap()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		and (Duel.IsExistingMatchingCard(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
		or Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,s.announce_filter)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		if g:IsExists(Card.IsCode,1,nil,ac) then
			local g1=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
			local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
			local op=Duel.SelectEffect(tp,{#g1>0,aux.Stringid(id,1)},{#g2>0,aux.Stringid(id,2)})
			if op==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
				local tc=g1:Select(tp,1,1,nil):GetFirst()
				Duel.GetControl(tc,tp)
			elseif op==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
				local tc=g2:Select(tp,1,1,nil):GetFirst()
				Duel.HintSelection(tc,true)
				if Duel.Destroy(tc,REASON_EFFECT)~=0
					and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
					and not tc:IsLocation(LOCATION_HAND|LOCATION_DECK)
					and tc:IsSpellTrap() and tc:IsSSetable()
					and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
					Duel.BreakEffect()
					Duel.SSet(tp,tc)
				end
			end
		end
		Duel.ShuffleHand(1-tp)
	end
end