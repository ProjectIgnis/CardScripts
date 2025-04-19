--トリックスターフロード
--Trickstar Trick
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
s.listed_series={0xfb}
function s.cfilter(c)
	return c:IsSetCard(SET_TRICKSTAR) and c:IsAbleToGrave()
end
function s.tkfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_TRICKSTAR)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	local ct=3-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	return Duel.GetTurnPlayer()~=tp and ct>0 and Duel.IsPlayerCanDraw(1-tp,ct)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opd check and ask if you want to activate the skill or not
	if Duel.GetFlagEffect(tp,id)>0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	--skill is active flag
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--check if skill is negated
	if aux.CheckSkillNegation(e,tp) then return end
	--Opponent draw/banish during EP
	local ct=3-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if ct>0 and Duel.IsPlayerCanDraw(1-tp,ct) and cg:GetFirst() then
		Duel.SendtoGrave(cg:Select(tp,1,1,nil),REASON_EFFECT)
		Duel.Draw(1-tp,ct,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetOperation(s.banop)
	Duel.RegisterEffect(e1,tp)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):Filter(Card.IsAbleToRemove,nil)
	local gyc=Duel.GetMatchingGroupCount(s.tkfilter,tp,LOCATION_GRAVE,0,nil)
	if #hg==0 or gyc==0 then return end
	if #hg<=gyc then
		Duel.Remove(hg,POS_FACEUP,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local bg=hg:Select(1-tp,gyc,gyc,nil)
		Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)
	end
end