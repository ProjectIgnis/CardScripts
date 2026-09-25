--沈黙の闘者－サイレント・マジシャン
--Silent Magician, the Silent Fighter
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned (from your hand) by Tributing 1 Level 7 or lower monster (Spellcaster or Warrior). You can only Special Summon "Silent Magician, the Silent Fighter" once per turn this way
	c:AddMustBeSpecialSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e0)
	--The first time this card would be destroyed by battle or card effect each turn, it is not destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetValue(function(e,re,r)
		return r&(REASON_BATTLE|REASON_EFFECT)>0
	end)
	c:RegisterEffect(e1)
	--Twice per turn, each time your opponent draws a card(s): You can draw 1 card, or if your opponent drew by their own card effect, you draw the same number of cards instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ep==1-tp
	end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local opp_eff_chk=rp==1-tp and r&REASON_EFFECT>0
		local draw_count=opp_eff_chk and #eg or 1
		if chk==0 then return Duel.IsPlayerCanDraw(tp,draw_count) end
		e:GetChainData().draw_count=draw_count
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,draw_count)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local draw_count=e:GetChainData().draw_count
		Duel.Draw(tp,draw_count,REASON_EFFECT)
	end)
	c:RegisterEffect(e2)
	--While you have 6 or more cards in your hand, negate all your opponent's activated Spell Cards and effects
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=6
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if rp==1-tp and re:IsSpellEffect() then
			Duel.Hint(HINT_CARD,0,id)
			Duel.NegateEffect(ev)
		end
	end)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.spcostfilter(c)
	return c:IsLevelBelow(7) and c:IsRace(RACE_SPELLCASTER|RACE_WARRIOR)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.spcostfilter,1,false,1,true,c,tp,nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.spcostfilter,1,1,false,true,true,c,tp,nil,false,nil)
	if g then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.Release(g,REASON_COST)
	end
end