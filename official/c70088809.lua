--調和ノ天救竜
--Fidraulis Harmonia
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a monster effect on the field (Quick Effect): You can reveal this card in your hand and up to 5 Synchro Monsters in your Extra Deck; apply these effects in sequence based on the total number revealed, also you cannot activate the effects of monsters Special Summoned from the Extra Deck until the end of your next turn, except Synchro Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.effcon)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
function s.revealfilter(c)
	return c:IsSynchroMonster() and not c:IsPublic()
end
function s.rescon(sg,e,tp,mg)
	local b1=#sg==1
	local b2=#sg==3 and sg:IsExists(Card.IsAbleToGrave,1,nil)
	local b3=#sg==5 and sg:IsExists(Card.IsAbleToGrave,1,nil) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
	return b1 or b2 or b3
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.revealfilter,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return not c:IsPublic() and #g>0 end
	local max_reveal_count=math.min(#g,5)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,max_reveal_count,s.rescon,1,tp,HINTMSG_CONFIRM,s.rescon)
	Duel.ConfirmCards(1-tp,c)
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleExtra(tp)
	e:SetLabel(#sg+1)
	e:SetLabelObject(sg)
	for sc in sg:Iter() do
		sc:CreateEffectRelation(e)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local reveal_count=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	if reveal_count>=4 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	end
	if reveal_count==6 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetFieldGroup(tp,0,LOCATION_MZONE),1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local break_chk=false
	local reveal_count=e:GetLabel()
	if reveal_count>=2 and c:IsRelateToEffect(e) then
		--● 2+: Special Summon this card
		break_chk=true
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	if reveal_count>=4 then
		--● 4+: Send 1 of the revealed Synchro Monsters to the GY
		local revealed_synchros=e:GetLabelObject():Match(Card.IsRelateToEffect,nil,e)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=revealed_synchros:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
		if #g>0 then
			if break_chk then Duel.BreakEffect() end
			break_chk=true
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
	if reveal_count==6 then
		--● 6: Destroy 1 monster your opponent controls
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			if break_chk then Duel.BreakEffect() end
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	local reset_count=Duel.IsTurnPlayer(tp) and 2 or 1
	--You cannot activate the effects of monsters Special Summoned from the Extra Deck until the end of your next turn, except Synchro Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,reset_count)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsOnField() and rc:IsSummonLocation(LOCATION_EXTRA)
		and not rc:IsSynchroMonster()
end