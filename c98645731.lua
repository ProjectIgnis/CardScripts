--強欲で謙虚な壺
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=true
		s[1]=true
		s[2]={}
		s[3]={}
		s[4]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.checkop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAIN_NEGATED)
		ge2:SetOperation(s.checkop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_CHAIN_SOLVED)
		ge3:SetOperation(s.checkop3)
		Duel.RegisterEffect(ge3,0)
		local ge4=Effect.CreateEffect(c)
		ge4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge4:SetCode(EVENT_ADJUST)
		ge4:SetCountLimit(1)
		ge4:SetOperation(s.clear)
		Duel.RegisterEffect(ge4,0)
	end)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and not s[tp] end
	--oath effects
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		local g=Duel.GetDecktopGroup(tp,3)
		local result=g:FilterCount(Card.IsAbleToHand,nil)>0
		return result
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(p,3)
	local g=Duel.GetDecktopGroup(p,3)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
		local sg=g:Select(p,1,1,nil)
		if sg:GetFirst():IsAbleToHand() then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-p,sg)
			Duel.ShuffleHand(p)
		else
			Duel.SendtoGrave(sg,REASON_RULE)
		end
		Duel.ShuffleDeck(p)
	end
end
function s.checkop1(e,tp,eg,ep,ev,re,r,rp)
	if not s[0] then
		local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
		if ex then
			if cg and #cg>0 then
				if rp==0 or cp==PLAYER_ALL then
					s[2][ev]=true
				end
			else
				local ex2,cg2,ct2,cp2,cv2=Duel.GetOperationInfo(ev,CATEGORY_TOKEN)
				if ex2 then
					if cp==0 or cp==PLAYER_ALL then
						s[2][ev]=true
					end
				else
					if rp==0 or cp==0 or cp==PLAYER_ALL then
						s[2][ev]=true
					end
				end
			end
			if ev>s[4] then
				s[4]=ev
			end
		end
	end
	if not s[1] then
		local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
		if ex then
			if cg and #cg>0 then
				if rp==1 or cp==PLAYER_ALL then
					s[3][ev]=true
				end
			else
				local ex2,cg2,ct2,cp2,cv2=Duel.GetOperationInfo(ev,CATEGORY_TOKEN)
				if ex2 then
					if cp==1 or cp==PLAYER_ALL then
						s[2][ev]=true
					end
				else
					if rp==1 or cp==1 or cp==PLAYER_ALL then
						s[3][ev]=true
					end
				end
			end
			if ev>s[4] then
				s[4]=ev
			end
		end
	end
end
function s.checkop2(e,tp,eg,ep,ev,re,r,rp)
	if s[2][ev] then s[2][ev]=false end
	if s[3][ev] then s[3][ev]=false end
end
function s.checkop3(e,tp,eg,ep,ev,re,r,rp)
	if ev~=1 or s[4]<=0 then return end
	for i=1,s[4] do
		if s[2][i] then s[0]=true end
		if s[3][i] then s[1]=true end
	end
	s[4]=0
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=false
	s[1]=false
	s[2]={}
	s[3]={}
	s[4]=0
end
