--ＲＲ－ファイナル・フォートレス・ファルコン (Anime)
--Raidraptor - Final Fortress Falcon (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 12 Winged Beast monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WINGEDBEAST),12,3)
	--Return all your banished "Raidraptor" monsters to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Detach(1))
	e1:SetTarget(s.rtgtg)
	e1:SetOperation(s.rtgop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Allow 1 "Raidraptor" monster to attack multiple times in a row
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RAIDRAPTOR}
function s.rtgfilter(c)
	return c:IsSetCard(SET_RAIDRAPTOR) and c:IsMonster() and c:IsFaceup()
end
function s.rtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rtgfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,0)
end
function s.rtgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rtgfilter,tp,LOCATION_REMOVED,0,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT|REASON_RETURN)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	return ac and ac:IsRelateToBattle() and ac:IsSetCard(SET_RAIDRAPTOR) and ac:IsControler(tp)
		and ac:CanChainAttack(ac:GetAttackAnnouncedCount()+1,true)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	if chk==0 then return ct>0 and c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	local g=c:GetOverlayGroup()
	Duel.SendtoGrave(g,REASON_COST)
end
function s.rmfilter(c)
	return c:IsSetCard(SET_RAIDRAPTOR) and c:IsType(TYPE_XYZ) and c:IsAbleToRemove()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	if not (ac:IsRelateToBattle() and ac:IsSetCard(SET_RAIDRAPTOR)) then return end
	local ct=Duel.GetMatchingGroupCount(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		s.chainatkop(c,ac)
		if #g==1 then return end
		--For each "Raidraptor" Xyz Monster you banish from your Graveyard, that "Raidraptor" monster can attack an opponent's monster again in a row
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EVENT_DAMAGE_STEP_END)
		e1:SetCountLimit(#g-1)
		e1:SetCondition(s.chainatkcon)
		e1:SetOperation(function() s.chainatkop(c,ac) end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		ac:RegisterEffect(e1)
		--Reset the above effect if another monster attacks
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetCondition(function() return Duel.GetAttacker()~=ac end)
		e2:SetOperation(function() if e1 then e1:Reset() end e2:Reset() end)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.chainatkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetAttacker()==c and c:CanChainAttack(c:GetAttackAnnouncedCount()+1,true)
end
function s.chainatkop(c,ac)
	Duel.ChainAttack()
	--The consecutive attack must be on a monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE|PHASE_DAMAGE_CAL)
	ac:RegisterEffect(e1)
end