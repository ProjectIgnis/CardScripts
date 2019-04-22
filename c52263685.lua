--盗み見ゴブリン
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3 end
	Duel.SetTargetPlayer(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.GetFieldGroupCount(p,0,LOCATION_DECK)==0 then return end
	Duel.ConfirmDecktop(1-p,3)
	local g=Duel.GetDecktopGroup(1-p,3)
	local ct=#g
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(id,0))
		local sg=g:Select(p,1,1,nil)
		Duel.MoveSequence(sg:GetFirst(),1)
		Duel.ConfirmCards(1-p,sg)
		Duel.SortDecktop(p,1-p,ct-1)
		Duel.ConfirmDecktop(1-p,ct-1)
	end
end
