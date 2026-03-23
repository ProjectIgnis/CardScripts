--闇の神－ダークゴッド
--Dark Creator
--scripted by Naim
local s,id=GetID()
local TOKEN_DARK_CREATOR=id+1
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by Tributing 2 Fiend and/or Fairy monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	--Cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Once per turn: You can Special Summon as many "Dark Creator Tokens" (Fiend/DARK/Level 10/ATK 3000/DEF 1000) as possible, but they cannot attack directly or be destroyed by battle, destroy them when this card is destroyed, also you cannot Special Summon for the rest of this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.tokensptg)
	e3:SetOperation(s.tokenspop)
	c:RegisterEffect(e3)
	--If a monster(s) is destroyed by battle: Inflict 700 damage to your opponent
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
s.listed_names={TOKEN_DARK_CREATOR}
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,Card.IsRace,2,false,2,true,c,tp,nil,false,nil,RACE_FIEND|RACE_FAIRY)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,2,2,false,true,true,c,tp,nil,false,nil,RACE_FIEND|RACE_FAIRY)
	if g then
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.Release(g,REASON_COST)
	end
end
function s.tokensptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DARK_CREATOR,0,TYPES_TOKEN,3000,1000,10,RACE_FIEND,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.tokenspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DARK_CREATOR,0,TYPES_TOKEN,3000,1000,10,RACE_FIEND,ATTRIBUTE_DARK) then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local sg=Group.CreateGroup()
		for i=1,ft do
			local token=Duel.CreateToken(tp,TOKEN_DARK_CREATOR)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			sg:AddCard(token)
			--They cannot attack directly or be destroyed by battle
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3207)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetDescription(3000)
			e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e2:SetValue(1)
			token:RegisterEffect(e2,true)
		end
		if c:IsRelateToEffect(e) and #sg>0 then
			--Destroy them when this card is destroyed
			local e3a=Effect.CreateEffect(c)
			e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3a:SetCode(EVENT_LEAVE_FIELD_P)
			e3a:SetCondition(function() return c:IsReason(REASON_DESTROY) end)
			e3a:SetOperation(function()
					local e3b=Effect.CreateEffect(c)
					e3b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
					e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e3b:SetCode(EVENT_DESTROYED)
					e3b:SetOperation(function(e)
							local dg=sg:Filter(Card.IsOnField,nil)
							if #dg>0 then
								Duel.Hint(HINT_CARD,1-tp,id)
								Duel.Destroy(dg,REASON_EFFECT)
							end
							e:Reset()
						end)
					c:RegisterEffect(e3b)
				end)
			e3a:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e3a)
		end
		Duel.SpecialSummonComplete()
	end
	--You cannot Special Summon for the rest of this turn
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e4,tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(700)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,700)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end