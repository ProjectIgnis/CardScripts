--幻刃工兵ドラフタンニム 
--Draftannium the Mythic Sword Engineer
local s,id=GetID()
function s.initial_effect(c)
	--Send to GY and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsStatus(STATUS_SUMMON_TURN)		
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=1 end
	Duel.SetTargetPlayer(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetFieldGroupCountRush(tp,0,LOCATION_ONFIELD)
	Duel.ConfirmDecktop(p,1)
	local g=Duel.GetDecktopGroup(p,ct)
	if Duel.SelectOption(p,aux.Stringid(id,0),aux.Stringid(id,1))==1 then
		Duel.MoveToDeckBottom(g)
		Duel.SortDeckbottom(p,p,#g)
	else
		Duel.SortDecktop(p,p,#g)
	end
end
