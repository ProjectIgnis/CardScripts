--Rainbow Blessing
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={47408488}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(47408488)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	local lp=Duel.GetLP(tp)
	local t={}
	local f=math.floor((lp)/1000)
	local l=1
	while l<=f and l<=20 do
		t[l]=l*1000
		l=l+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17078030,0))
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,announce)
	Duel.SetTargetParam(announce/1000)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0x6,announce/1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,0,nil)
	if #g<=0 then return end
	if #g==1 then
		local sc=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,nil)
		Duel.HintSelection(Group.FromCards(sc))
		sc:AddCounter(0x6,ct)
	else
		while #g>1 and ct>0 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sg=g:Select(tp,1,1,nil)
			local sc=sg:GetFirst()
			local t={}
			local i=1
			local lv=e:GetHandler():GetLevel()
			for i=1,ct do 
				t[i]=i
			end
			local tempct=Duel.AnnounceNumber(tp,table.unpack(t))
			ct=ct-tempct
			Duel.HintSelection(sg)
			sc:AddCounter(0x6,tempct)
			g:RemoveCard(sc)
		end
		if #g==1 and ct>0 then
			local sc=g:GetFirst()
			Duel.HintSelection(Group.FromCards(sc))
			sc:AddCounter(0x6,ct)
		end
	end
end
