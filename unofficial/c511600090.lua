--超天新龍オッドアイズ・レボリューション・ドラゴン (Manga)
--Odd-Eyes Revolution Dragon (Manga)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--Special Summon Restriction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special Summon procedure: Tribute 1 each "Starving Venom Fusion Dragon", "Clear Wing Synchro Dragon", and "Dark Rebellion Xyz Dragon"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.hspcon)
	e2:SetTarget(s.hsptg)
	e2:SetOperation(s.hspop)
	c:RegisterEffect(e2)
	--ATK/DEF become equal to your opponent's LP
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(function(e,c) return math.floor(Duel.GetLP(1-e:GetHandlerPlayer())) end)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e4)
	--Shuffle all cards on the field and in the GYs into the Deck, except for this card
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(16306932,2))
	e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(Cost.PayLP(1/2))
	e5:SetTarget(s.tdtg)
	e5:SetOperation(s.tdop)
	c:RegisterEffect(e5)
end
s.listed_names={41209827,82044279,16195942}
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),41209827,82044279,16195942)
end
function s.chk(c,sg,g,code,...)
	if not c:IsCode(code) then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp)
	local g1=rg:Filter(Card.IsCode,nil,41209827)
	local g2=rg:Filter(Card.IsCode,nil,82044279)
	local g3=rg:Filter(Card.IsCode,nil,16195942)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 and #g1>0 and #g2>0 and #g3>0 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp)
	local g1=rg:Filter(Card.IsCode,nil,41209827)
	local g2=rg:Filter(Card.IsCode,nil,82044279)
	local g3=rg:Filter(Card.IsCode,nil,16195942)
	g1:Merge(g2)
	g1:Merge(g3)
	local g1=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_RELEASE,s.rescon,nil,true)
	if #g1>0 then
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g1=e:GetLabelObject()
	if not g1 then return end
	Duel.Release(g1,REASON_COST)
	g1:DeleteGroup()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,e:GetHandler())
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end