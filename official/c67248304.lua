--リバースポッド
--Reverse Jar
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Change as many other monsters to face-down defense
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local fdg=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local thg=Duel.GetMatchingGroup(aux.AND(Card.IsAbleToHand,aux.FaceupFilter(Card.IsType,TYPE_SPELL|TYPE_TRAP)),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,fdg,#fdg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,thg,#thg,0,0)
end
	--Change as many other monsters to face-down defense
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then return end
	if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)==0 then return end
	local g2=Duel.GetMatchingGroup(aux.AND(Card.IsAbleToHand,aux.FaceupFilter(Card.IsType,TYPE_SPELL|TYPE_TRAP)),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g2==0 then return end
	Duel.BreakEffect()
	if Duel.SendtoHand(g2,nil,REASON_EFFECT)==0 then return end
	g2=Duel.GetOperatedGroup():Match(Card.IsLocation,nil,LOCATION_HAND)
	local ct1=g2:FilterCount(Card.IsControler,nil,tp)
	local ct2=#g2-ct1
	local sel=false
	--Each player can Set Spells/Traps from hand
	local turn_p=Duel.GetTurnPlayer()
	local step=turn_p==0 and 1 or -1
	for p=turn_p,1-turn_p,step do
		local setg=Duel.GetMatchingGroup(Card.IsSSetable,p,LOCATION_HAND,0,nil)
		local setmax_ct=0
		if p==tp then
			setmax_ct=math.min(#setg,ct1)
		else
			setmax_ct=math.min(#setg,ct2)
		end
		if #setg>0 and setmax_ct>0 and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
			Duel.ShuffleHand(p)
			if not sel then Duel.BreakEffect() end
			sel=true
			local sg=aux.SelectUnselectGroup(setg,e,p,1,setmax_ct,s.rescon,1,p,HINTMSG_SET)
			Duel.SSet(p,sg,p,false)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSSetable,nil)==#sg
		and sg:FilterCount(aux.NOT(Card.IsType),nil,TYPE_FIELD)<=Duel.GetLocationCount(tp,LOCATION_SZONE)
		and sg:FilterCount(Card.IsType,nil,TYPE_FIELD)<=1
end