--サイバーポッド
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.spchk(c,e,tp)
	return (c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) 
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
	Duel.BreakEffect()
	local p=Duel.GetTurnPlayer()
	local g1=Duel.GetDecktopGroup(p,5)
	local g2=Duel.GetDecktopGroup(1-p,5)
	local spg=g1:Clone()
	spg:Merge(g2)
	local hg=Group.CreateGroup()
	local gg=Group.CreateGroup()
	Duel.ConfirmDecktop(p,5)
	local tc=g1:GetFirst()
	while tc do
		local lv=tc:GetLevel()
		local pos=0
		if s.spchk(tc,e,tc:GetControler()) and Duel.IsPlayerAffectedByEffect(tc:GetControler(),CARD_BLUEEYES_SPIRIT) then
			gg:AddCard(tc)
		else
			if tc:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK) then pos=pos+POS_FACEUP_ATTACK end
			if tc:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEDOWN_DEFENSE) then pos=pos+POS_FACEDOWN_DEFENSE end
			if lv>0 and lv<=4 and pos~=0 then
				Duel.DisableShuffleCheck()
				Duel.SpecialSummonStep(tc,0,p,p,false,false,pos)
			elseif tc:IsAbleToHand() then
				hg:AddCard(tc)
			else gg:AddCard(tc) end
		end
		tc=g1:GetNext()
	end
	Duel.ConfirmDecktop(1-p,5)
	tc=g2:GetFirst()
	while tc do
		local lv=tc:GetLevel()
		local pos=0
		if s.spchk(tc,e,tc:GetControler()) and Duel.IsPlayerAffectedByEffect(tc:GetControler(),CARD_BLUEEYES_SPIRIT) then
			gg:AddCard(tc)
		else
			if tc:IsCanBeSpecialSummoned(e,0,1-p,false,false,POS_FACEUP_ATTACK) then pos=pos+POS_FACEUP_ATTACK end
			if tc:IsCanBeSpecialSummoned(e,0,1-p,false,false,POS_FACEDOWN_DEFENSE) then pos=pos+POS_FACEDOWN_DEFENSE end
			if lv>0 and lv<=4 and pos~=0 then
				Duel.DisableShuffleCheck()
				Duel.SpecialSummonStep(tc,0,1-p,1-p,false,false,pos)
			elseif tc:IsAbleToHand() then
				hg:AddCard(tc)
			else gg:AddCard(tc) end
		end
		tc=g2:GetNext()
	end
	Duel.SpecialSummonComplete()
	if #hg>0 then
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		Duel.ShuffleHand(tp)
		Duel.ShuffleHand(1-tp)
	end
	if #gg>0 then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(gg,REASON_EFFECT)
	end
	local fg=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ShuffleSetCard(fg)
end
