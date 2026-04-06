--嗚呼な落とし穴
--Oh my Trap Hole!
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When a monster effect is activated on your opponent's field during the turn they Special Summoned a monster(s): Destroy the monster that activated that effect, then destroy all opponent's cards in its adjacent Monster Zones and Spell & Trap Zones (if any)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Keep track of a player Special Summoning a monster
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
							for p=0,1 do
								if eg:IsExists(Card.IsSummonPlayer,1,nil,p) then
									Duel.RegisterFlagEffect(p,id,RESET_PHASE|PHASE_END,0,1)
								end
							end
						end
					)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.HasFlagEffect(1-tp,id) and re:IsMonsterEffect()) then return false end
	local trig_loc,trig_ctrl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	return trig_ctrl==1-tp and trig_loc==LOCATION_MZONE and re:GetHandler():IsRelateToEffect(re)
end
function s.adjacentfilter(c,tp,rc,seq)
	if c:IsControler(tp) then return false end
	if c:IsLocation(LOCATION_SZONE) then
		return rc:IsInMainMZone() and rc:GetColumnGroup():IsContains(c) and c:IsControler(rc:GetControler())
	elseif c:IsLocation(LOCATION_MZONE) then
		if c:IsInExtraMZone() or rc:IsInExtraMZone() then
			return rc:GetColumnGroup():IsContains(c)
		else
			return c:IsSequence(seq-1,seq+1) and c:IsControler(rc:GetControler())
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	rc:CreateEffectRelation(e)
	local g=rc:GetColumnGroup(1,1):Match(s.adjacentfilter,nil,tp,rc,rc:GetSequence())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g+rc,#g+1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsRelateToEffect(re) then return end
	local g=rc:GetColumnGroup(1,1):Match(s.adjacentfilter,nil,tp,rc,rc:GetSequence())
	if Duel.Destroy(rc,REASON_EFFECT)>0 and #g>0 then
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end