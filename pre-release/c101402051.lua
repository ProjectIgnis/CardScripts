--解層竜ストラティアエ
--Destratification Dino Stratiae
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters, including a Dinosaur monster
	Link.AddProcedure(c,nil,2,2,s.linkmatcheck)
	--Keep track of the total original ATK of the Dinosaur monsters used as its material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(function(e,c)
		local mg=c:GetMaterial():Match(Card.IsRace,nil,RACE_DINOSAUR,c,SUMMON_TYPE_LINK,e:GetHandlerPlayer())
		e:SetLabel(mg:GetSum(Card.GetBaseAttack)//2)
	end)
	c:RegisterEffect(e0)
	--If this card is Link Summoned: You can make this card gain ATK equal to half the total original ATK of the Dinosaur monsters used as its material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e)
		return e:GetHandler():IsLinkSummoned() and e0:GetLabel()>0
	end)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		local atk=e0:GetLabel()
		e:GetChainData().atk=atk
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,atk)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			--Make this card gain ATK equal to half the total original ATK of the Dinosaur monsters used as its material
			c:UpdateAttack(e:GetChainData().atk)
		end
	end)
	c:RegisterEffect(e1)
	--During your Main Phase: You can Fusion Summon 1 Dinosaur Fusion Monster from your Extra Deck, by banishing its materials from your field and/or GY, also you cannot Special Summon from the Extra Deck for the rest of this turn, except Dinosaur monsters. You can only use this effect of "Destratification Dino Stratiae" once per turn
	local fusion_params={
		fusfilter=function(c) return c:IsRace(RACE_DINOSAUR) end,
		matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),
		extrafil=function(e,tp,mg)
			if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
				return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
			end
			return nil
		end,
		extraop=Fusion.BanishMaterial,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE|LOCATION_GRAVE)
		end,
		stage2=function(e,fc,tp,mg,chk)
			if chk~=2 then return end
			local c=e:GetHandler()
			--You cannot Special Summon from the Extra Deck for the rest of this turn, except Dinosaur monsters
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and c:IsRaceExcept(RACE_DINOSAUR) end)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			--"Clock Lizard" check
			aux.addTempLizardCheck(c,tp,function(c) return not c:IsOriginalRace(RACE_DINOSAUR) end)
		end
	}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(Fusion.SummonEffTG(fusion_params))
	e2:SetOperation(Fusion.SummonEffOP(fusion_params))
	c:RegisterEffect(e2)
end
function s.linkmatcheck(g,linkc,sumtype,tp)
	return g:IsExists(Card.IsRace,1,nil,RACE_DINOSAUR,linkc,sumtype,tp)
end